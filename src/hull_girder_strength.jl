include(srcdir("global_loads.jl"))

function get_F_sigma_hg(x)
	if x <= 0.3
		F_sigma_hg = 0.319 + 2.311 * x - 2.974 * x^2
	elseif 0.3 < x <= 0.7
		F_sigma_hg = 0.75
	elseif 0.7 < x
		F_sigma_hg = 0.319 + 2.311 * (1-x) - 2.974 * (1-x)^2
	end
end

function get_F_sigma_hg_array()
	x = get_x_array()
	F_sigma_hg = get_F_sigma_hg.(x)
	return F_sigma_hg
end

function get_F_sigma_ws()
	F_sigma_ws = 1.2
	return F_sigma_ws
end

function get_sigma_o_MS()
	sigma_o_MS = 250 # N/mm^2 (MPa)
	return sigma_o_MS
end

function get_sigma_D(M_r, Z_d)
	sigma_D = M_r / 1000 * Z_d
	return sigma_D
end

function get_sigma_B(M_r, Z_b)
	sigma_B = M_r / 1000 * Z_b
	return sigma_B
end

function get_sigma_ws(M_wh, M_ws, Z_d)
	sigma_ws = (M_wh - M_ws) / 1000 * Z_d
	return sigma_ws
end

function get_sigma_o()
	sigma_o = 240 # N/mm^2 (MPa)
	return sigma_o
end

function get_F_hts()
	sigma_o = get_sigma_o()
	if sigma_o >= 235
		F_hts = 1.0
	elseif 235 < sigma_o < 265
		F_hts = linear_interpolation(sigma_o, 235, 265, 1.0, 0.964)
	elseif sigma_o >= 265
		F_hts = 0.964
	elseif 265 < sigma_o < 315
		F_hts = linear_interpolation(sigma_o, 265, 315, 0.964, 0.956)
	elseif sigma_o >= 315
		F_hts = 0.956
	elseif 315 < sigma_o < 355
		F_hts = linear_interpolation(sigma_o, 315, 355, 0.956, 0.919)
	elseif sigma_o >= 355
		F_hts = 0.919
	elseif 355 < sigma_o < 390
		F_hts = linear_interpolation(sigma_o, 355, 390, 0.919, 0.886)
	elseif sigma_o >= 390
		F_hts = 0.886(390/sigma_o)
	end
    return F_hts
end

function get_sigma_p()
	F_sigma_hg = get_F_sigma_hg_array()
	sigma_o = get_sigma_o()
	F_hts = get_F_hts()
	sigma_p = F_sigma_hg * F_hts * sigma_o
	return sigma_p
end
