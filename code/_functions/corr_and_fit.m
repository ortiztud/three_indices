function [rho, p_val] = corr_and_fit(x, y, n, method, do_perm, xlabels)

% Correlate two variables (x and y) and fit a given polynomial component.
% "method" provides the correlation method, "n" gives the number of the
% polynomial, do_perm = 1 creates a random distribution (iteration = 5000)
% and reports the 95 percentil. Will produce a plot. 

%% Prepare incomind data
% Data needs to be sorted in columns; otherwise a matrix correlation is
% computed which is not what we (you) want (most likely).
if size(x,2)>size(x,1)
    x = x';y = y';
end

%% Start
% Correlated
[rho, p_val] = corr(x,y,'type', method);

% Plot data
f = scatter(x, y);hold on

% Compute fit
params=polyfit(x, y,n);

% Get predicted data
pred = (x * params(1)) + params(2);

% Plot predicted
plot(x, pred)

% Get plot info
x_axis = f.Parent.XLim;
y_axis = f.Parent.YLim;
rangX = x_axis(1)-x_axis(2);rangY = y_axis(1)-y_axis(2);

if do_perm
    thr = perm_test(x, y,method, 5000);

    % Compose text
    sign_text = sprintf('perm. upper thr. = %.3f', thr.u);
else
    sign_text = sprintf('p = %.3f', p_val);

end

% Write info in plot
disp_text = sprintf('Rho (%s) = %.3f', method, rho);
% text(x_axis(1)+abs(rangX*10/100), y_axis(2)-abs(rangY*10/100), disp_text)
text(max(x)*.60, max(y)*.25, disp_text)
text(max(x)*.60, max(y)*.2, sign_text)

% Format
xlabel(xlabels(1));ylabel(xlabels(2))

%% Sub-functions
    function [thr, perm_rho] = perm_test(x, y,method,n_iterations)
        % Scramble labels in Y for n_iterations times.
        for i = 1:n_iterations

            % Scramble Y
            perm_y = y(randperm(length(y)));

            % Compute correlation
            perm_rho(i) = corr(x, perm_y, 'type', method);

            % Echo to console
            if mod(i,floor(n_iterations*.20))==0
                fprintf('Permutation test: %d%% completed \n\n', i/n_iterations*100)
            end
        end

        % Get threshold for 95% observations
        thr.u = prctile(perm_rho,95);
%         thr.l = prctile(perm_rho,2.5);
    end

end