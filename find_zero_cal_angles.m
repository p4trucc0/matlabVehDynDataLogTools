function [rho, beta] = find_zero_cal_angles(g_a)
% Find static calibration angles.


g0 = [0 0 -1]';
% rho1 = asin(-g_a(2));
rho1 = asin(g_a(2));
rho2 = pi - rho1;
% bet1 = atan2(-g_a(1), g_a(3));
bet1 = atan2(g_a(1), g_a(3));
bet2 = bet1 + pi;


rho = 0;
beta = 0;
c11 = ruota_coord(g_a, 0, bet1, rho1);
c12 = ruota_coord(g_a, 0, bet1, rho2);
c13 = ruota_coord(g_a, 0, bet2, rho1);
c14 = ruota_coord(g_a, 0, bet2, rho2);

[~, q] = min([eva_mod(c11) eva_mod(c12) eva_mod(c13) eva_mod(c14)]);
if q == 1
    rho = rho1;
    beta = bet1;
elseif q == 2
    rho = rho2;
    beta = bet1;
elseif q == 3
    rho = rho1;
    beta = bet2;
elseif q == 4
    rho = rho2;
    beta = bet2;
end

    function modulo = eva_mod(c)
        modulo = sum(c(1)^2+c(2)^2)^.5;
    end

end
