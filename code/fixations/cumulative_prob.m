% Initialize empty matrix
a = nan(120, 20);
a(a==0) = NaN;

con = a;
inc = a;
% Taken from Event Statistic - Single.xls
load('cumulative_prob_data.mat')
%% Congruent trials
for c_sub = 1:20

    curr_sub = target_fix.con(:,c_sub);

    n_misses = sum(isnan(curr_sub));
    for c_fix = 1:24
        fix_bin(c_fix) = sum(curr_sub<=c_fix);

    end
    cum_prob(:,c_sub) = fix_bin/(60);
end

con_cum = cum_prob;

%% Incongruent trials
for c_sub = 1:20

    curr_sub = target_fix.inc(:,c_sub);

    n_misses = sum(isnan(curr_sub));
    for c_fix = 1:24
        fix_bin(c_fix) = sum(curr_sub<=c_fix);

    end
    cum_prob(:,c_sub) = fix_bin/(60);
end

inc_cum = cum_prob;

figure(9998)
subplot(1,2,1), plot(con_cum)
subplot(1,2,2), plot(inc_cum)
figure(9999)
plot(mean(con_cum,2));hold on
plot(mean(inc_cum,2))


%% Stats
for c_fix = 1:24

    [H,p_val(c_fix),CI,STATS] = ttest(con_cum(c_fix,:),inc_cum(c_fix,:));

end
sign_ind = find(p_val < .01);
line([min(sign_ind),max(sign_ind)], [.85 .85])