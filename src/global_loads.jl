#= Generates parameters defined by the environmental conditions section of LR_NS. =#
include(srcdir("environmental_conditions.jl"))

function get_L_f(L_r)
    if L_r <= 90
        L_f = 0.0412*L_r + 4
	elseif L_r > 90 && L_r <= 300
        L_f = 10.75 - 1.5 * (300 - L_r)/100
	elseif L_r > 300 && L_r <= 350
        L_f = 10.75
    elseif L_r > 350
        L_f = 10.75 - 1.5 * (L_r - 350)/150
	end
	return L_f
end


function get_R_a(L_r, B_wl, A_ub, A_us, A_ls, A_lb)
	A_bf = A_ub - A_lb
	A_sf = A_us - A_ls
	R_a = 30 * (A_bf + 0.5 * A_sf)/get_L_f(L_r) * B_wl
	return R_a
end

function linear_interpolation(x, x_0, x_1, y_0, y_1)
	return y_0 + (x - x_0) * (y_1 - y_0)/(x_1 - x_0)
end

function get_D_f(x)
	if x == 0
		D_f = 0
	elseif 0 < x <= 0.4
		D_f = linear_interpolation(x, 0, 0.4, 0, 1)
	elseif 0.4 < x <= 0.65
		D_f = 1.0
	elseif  0.65 < x <= 1
		D_f = linear_interpolation(x, 0.65, 1, 1, 0)
	elseif x == 1
		D_f = 0
	end
	return D_f
end
function get_x_array()
	x = collect(0:0.0001:1)
	return x
end
function get_D_f_array()
	x = get_x_array()
	y = get_D_f.(x)
return [x, y]
end

function get_M_w(M_o, F_fh, F_fs)
	D_f = get_D_f_array()
	M_wh = D_f[2] * M_o * F_fh
	M_ws = D_f[2] * M_o * F_fs
	return [M_wh], [M_ws]
end


function get_M_w_array(C_b, L_wl, B_wl, L_r, A_ub, A_us, A_ls, A_lb, serviceAreaString)
	R_a = get_R_a(L_r, B_wl, A_ub, A_us, A_ls, A_lb)
    if R_a >= 1.0
        F_fs = -1.1 * R_a^0.3
    else
        F_fs = -1.1
	end

    if C_b < 0.6
        C_b = 0.6
	end

    F_fh = (1.9*C_b)/(C_b + 0.7)

    F_s = get_service_area_factors(serviceAreaString, L_wl, 20)[1]

    M_o = 0.1 * get_L_f(L_r) * F_s * L_r^2 * B_wl * (C_b + 0.7)

	M_w = get_M_w(M_o, F_fh, F_fs)
	M_wh = M_w[1]
	M_ws = M_w[2]

	return M_o, M_wh, M_ws, F_fh, F_fs
end

function get_K_f_pos(x, F_fs, F_fh)
	if x == 0
        K_f_pos = 0
	elseif  0 < x <= 0.2
		K_f_pos = linear_interpolation(x, 0, 0.2, 0, 0.836) * F_fh
	elseif 0.2 < x <= 0.3
        K_f_pos = 0.836 * F_fh
	elseif 0.3 < x <= 0.4
		K_f_pos = linear_interpolation(x, 0.3, 0.4, 0.836, 0.65) * F_fh
    elseif 0.4 < x <= 0.5
        K_f_pos = 0.65 * F_fh
	elseif 0.5 < x <= 0.6
		K_f_pos = -0.65 * F_fs
	elseif 0.6 < x <= 0.7
		K_f_pos = linear_interpolation(x, 0.6, 0.7, -0.65, -0.91) * F_fs
	elseif 0.7 < x <= 0.85
		K_f_pos = -0.91 * F_fs
	elseif 0.85 < x < 1
		K_f_pos = linear_interpolation(x, 0.85, 1, -0.91, 0) * F_fs
	elseif x == 1
        K_f_pos = 0
    end
	return K_f_pos
end

function get_K_f_neg(x, F_fs, F_fh)
	if x == 0
		K_f_neg = 0
	elseif  0 < x <= 0.2
		K_f_neg = linear_interpolation(x, 0, 0.2, 0, 0.836) * F_fs
	elseif 0.2 < x <= 0.3
		K_f_neg = 0.836 * F_fs
	elseif 0.3 < x <= 0.4
		K_f_neg = linear_interpolation(x, 0.3, 0.4, 0.836, 0.65) * F_fs
    elseif 0.4 < x <= 0.5
		K_f_neg = 0.65 * F_fs
	elseif 0.5 < x <= 0.6
		K_f_neg = -0.65 * F_fh
	elseif 0.6 < x <= 0.7
		K_f_neg = linear_interpolation(x, 0.6, 0.7, -0.65, -0.91) * F_fh
	elseif 0.7 < x <= 0.85
		K_f_neg = -0.91 * F_fh
	elseif 0.85 < x < 1
		K_f_neg = linear_interpolation(x, 0.85, 1, -0.91, 0) * F_fh
	elseif x == 1
		K_f_neg = 0
    end
	return K_f_neg
end

function get_K_f_array(F_fs, F_fh)
	x = get_x_array()
	ypos = get_K_f_pos.(x, F_fs, F_fh)
	yneg = get_K_f_neg.(x, F_fs, F_fh)
	return [ypos], [yneg]
end

function get_Q_w_array(M_o, L_r, F_fs, F_fh)
    K_f = get_K_f_array(F_fs, F_fh)
	Q_w_pos = (3 * K_f[1] * M_o)/L_r
	Q_w_neg = (3 * K_f[2] * M_o)/L_r
	return [Q_w_pos], [Q_w_neg]
end
