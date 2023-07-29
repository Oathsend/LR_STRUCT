include(srcdir("environmental_conditions.jl"))
include(srcdir("global_loads.jl"))

function get_K_f_EX()
	K_f_EX = 1.5
	return K_f_EX
end

function get_M_w_EX(C_b, L_wl, B_wl, L_r, A_ub, A_us, A_ls, A_lb, serviceAreaString)
    K_f_EX = get_K_f_EX()
	M_w = get_M_w_array(C_b, L_wl, B_wl, L_r, A_ub, A_us, A_ls, A_lb, serviceAreaString)
    M_wh_EX = K_f_EX * M_w[2]
	M_ws_EX = K_f_EX * M_w[3]
	return M_wh_EX, M_ws_EX
end

function get_Q_w_EX(M_o, L_r, F_fs, F_fh)
    K_f_EX = get_K_f_EX()
	Q_w = get_Q_w_array(M_o, L_r, F_fs, F_fh)
	Q_wh_EX = K_f_EX * Q_w[1]
	Q_ws_EX = K_f_EX * Q_w[2]
	return Q_wh_EX, Q_ws_EX
end

function get_M_r_EX(M_s)
	M_w_EX = get_M_w_EX(C_b, L_wl, B_wl, L_r, A_ub, A_us, A_ls, A_lb, serviceAreaString)
	M_r_EX = M_s + M_w_EX
	return M_r_EX
end

function get_Q_r_EX(Q_s)
	Q_w_EX = get_Q_w_EX(M_o, L_r, F_fs, F_fh)
	Q_r_EX = Q_s + Q_w_EX
	return Q_r_EX
end
