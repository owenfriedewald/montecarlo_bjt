%% BJT Bias Monte Carlo Analysis
% Nominal parameters
VCC_nom = 12;          % Volts
R1_nom  = 820e3;       % Ohms
R2_nom  = 390e3;       % Ohms
RC_nom  = 56e3;        % Ohms
RE_nom  = 39e3;        % Ohms
beta_nom = 80;         % unitless

Ns = [50, 100, 200, 500];  % Monte Carlo iteration counts

%% Helper function for Q-point computation
% Returns [ICQ, VCEQ] for given element values
biasPoint = @(R1,R2,RC,RE,VCC,beta) ...
    computeBias(R1,R2,RC,RE,VCC,beta);

%% Check nominal operating point
[IC_nom, VCE_nom] = biasPoint(R1_nom,R2_nom,RC_nom,RE_nom,VCC_nom,beta_nom);
fprintf('Nominal ICQ = %.3f uA\n', IC_nom*1e6);
fprintf('Nominal VCEQ = %.3f V\n\n', VCE_nom);

%% === (1) Global Monte Carlo: all variations active ===
% Tolerances:
tol_R   = 0.10;   % 10%% for all resistors
tol_VCC = 0.05;   % 5%% for VCC
tol_beta= 0.50;   % 50%% for beta

figure;
set(gcf,'Name','Global Monte Carlo (all elements varying)');

case_idx = 1;

for n_index = 1:length(Ns)
    N = Ns(n_index);

    IC_vals  = zeros(N,1);
    VCE_vals = zeros(N,1);

    for k = 1:N
        % Uniform random variation in +/- tolerance
        R1  = R1_nom  * (1 + tol_R   * (2*rand - 1));
        R2  = R2_nom  * (1 + tol_R   * (2*rand - 1));
        RC  = RC_nom  * (1 + tol_R   * (2*rand - 1));
        RE  = RE_nom  * (1 + tol_R   * (2*rand - 1));
        VCC = VCC_nom * (1 + tol_VCC * (2*rand - 1));
        beta= beta_nom* (1 + tol_beta* (2*rand - 1));

        [IC_vals(k), VCE_vals(k)] = biasPoint(R1,R2,RC,RE,VCC,beta);
    end

    % Compute statistics
    IC_mean  = mean(IC_vals);
    IC_std   = std(IC_vals);
    VCE_mean = mean(VCE_vals);
    VCE_std  = std(VCE_vals);

    fprintf('Global: N = %d\n', N);
    fprintf('  ICQ:  mean = %.3f uA, std = %.3f uA\n', IC_mean*1e6, IC_std*1e6);
    fprintf('  VCEQ: mean = %.3f V,  std = %.3f V\n\n', VCE_mean, VCE_std);

    % Plot histograms (ICQ)
    subplot(4,2,2*n_index-1);
    histogram(IC_vals*1e6);
    xlabel('ICQ (uA)');
    ylabel('Count');
    title(sprintf('Global ICQ, N=%d, \\mu=%.2f uA, \\sigma=%.2f uA', ...
        N, IC_mean*1e6, IC_std*1e6));

    % Plot histograms (VCEQ)
    subplot(4,2,2*n_index);
    histogram(VCE_vals);
    xlabel('VCEQ (V)');
    ylabel('Count');
    title(sprintf('Global VCEQ, N=%d, \\mu=%.2f V, \\sigma=%.2f V', ...
        N, VCE_mean, VCE_std));
end

%% === (a) Case 1: only RC and RE vary (10%%), others nominal ===
caseNames = {'Case 1: RC, RE vary',...
             'Case 2: R1, R2 vary',...
             'Case 3: beta varies'};

for case_num = 1:3

    figure;
    set(gcf,'Name',caseNames{case_num});

    for n_index = 1:length(Ns)
        N = Ns(n_index);

        IC_vals  = zeros(N,1);
        VCE_vals = zeros(N,1);

        for k = 1:N
            % Start with nominal
            R1  = R1_nom;
            R2  = R2_nom;
            RC  = RC_nom;
            RE  = RE_nom;
            VCC = VCC_nom;
            beta= beta_nom;

            switch case_num
                case 1  % Case 1: only RC and RE have 10%% tolerance
                    RC  = RC_nom * (1 + tol_R * (2*rand - 1));
                    RE  = RE_nom * (1 + tol_R * (2*rand - 1));
                case 2  % Case 2: only R1 and R2 have 10%% tolerance
                    R1  = R1_nom * (1 + tol_R * (2*rand - 1));
                    R2  = R2_nom * (1 + tol_R * (2*rand - 1));
                case 3  % Case 3: only beta has 50%% tolerance
                    beta = beta_nom * (1 + tol_beta * (2*rand - 1));
            end

            [IC_vals(k), VCE_vals(k)] = biasPoint(R1,R2,RC,RE,VCC,beta);
        end

        % Compute statistics
        IC_mean  = mean(IC_vals);
        IC_std   = std(IC_vals);
        VCE_mean = mean(VCE_vals);
        VCE_std  = std(VCE_vals);

        fprintf('%s: N = %d\n', caseNames{case_num}, N);
        fprintf('  ICQ:  mean = %.3f uA, std = %.3f uA\n', IC_mean*1e6, IC_std*1e6);
        fprintf('  VCEQ: mean = %.3f V,  std = %.3f V\n\n', VCE_mean, VCE_std);

        % Plot histograms (ICQ)
        subplot(4,2,2*n_index-1);
        histogram(IC_vals*1e6);
        xlabel('ICQ (uA)');
        ylabel('Count');
        title(sprintf('ICQ, N=%d, \\mu=%.2f uA, \\sigma=%.2f uA', ...
            N, IC_mean*1e6, IC_std*1e6));

        % Plot histograms (VCEQ)
        subplot(4,2,2*n_index);
        histogram(VCE_vals);
        xlabel('VCEQ (V)');
        ylabel('Count');
        title(sprintf('VCEQ, N=%d, \\mu=%.2f V, \\sigma=%.2f V', ...
            N, VCE_mean, VCE_std));
    end
end

%% === Local function for bias computation ===
function [IC, VCE] = computeBias(R1,R2,RC,RE,VCC,beta)
    % Thevenin equivalent
    Vth = VCC * R2 / (R1 + R2);
    Rth = (R1 * R2) / (R1 + R2);

    % Base current
    IB = (Vth - 0.7) / ( (beta + 1)*RE + Rth );

    % Currents
    IC = beta * IB;
    IE = (beta + 1) * IB;

    % Voltages
    VE  = IE * RE;
    VC  = VCC - IC * RC;
    VCE = VC - VE;
end