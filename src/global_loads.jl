#= Generates parameters defined by the environmental conditions section of LR_NS. =#

include(srcdir("environmental_conditions.jl"))

function get_l_f(L_r::Float64)
#=  Calculate L_f.

    variables:
    L_r - Rule length [m]

=#

    if L_r <= 90
        L_f = 0.0412*L_r + 4
	elseif L_r > 90 && L_r <= 300
        L_f = 10.75 - 1.5 * (300 - L_r)/100
	elseif L_r > 300 && L_r <= 350
        L_f = 10.75
    else
        L_f = 10.75 - 1.5 * (L_r - 350)/150
	end

return L_f
end


function calculate_area_ratio(L_r::Float64, T_d::Float64, B_wl::Float64, A_ub::Float64, A_us::Float64, A_ls::Float64)
	#= Calculate the area ratio of combined stern and bow shape.

	variables:
	L_r - Rule length [m]
	T_d - Design draught [m]
	B_wl - Maximum waterline breadth [m]
	A_ub - half of the waterplane area at a waterline of T_cu of the bow region forward of 0.8L_r from the AP [m^2]
	A_lb - half of the waterplane area at the design draught of the bow region backward of 0.8L_r from the AP [m^2]
	A_us - half of the waterplane area at a waterline of T_cu of the stern region aft to 0.2L_r forward of the AP [m^2]
	A_ls - half of the waterplane area at a waterline of T_cl of the stern region aft to 0.2L_r forward of the AP [m^2]
	=#


A_bf = A_ub - A_lb
A_sf = A_us - A_ls

R_a = 30 * (A_bf + 0.5 * A_sf)/get_l_f(L_r) * B_wl

return R_a
end

function linear_interpolation(x::Float64, x_0::Float64, x_1::Float64, y_0::Float64, y_1::Float64)
	#= Linear interpolation.

    variables:
	x - x value of the point where y is to be determined.
	x_0 - x value of the first point
	x_1 - x value of the second point
	y_0 - y value of the first point
	y_1 - y value of the second point
    =#
return y_0 + (x - x_0) * (y_1 - y_0)/(x_1 - x_0)
end

function get_vertical_bending_moment(R_a::Float64, C_b::Float64, L_wl::Float64, B_wl::Float64, L_r::Float64, serviceAreaString::AbstractString)
	#= =#
    if R_a >= 1.0
        F_fs = -1.1 * R_a^0.3
    else
        F_fs = -1.1
	end

    if C_b < 0.6
        C_b = 0.6
	end

    F_fh = (1.9*C_b)/(C_b + 0.7)

    if serviceAreaString == "SAR"
        serviceAreas = ((1, 0.5), (2, 0.25), (3, 0.25))
        F_s = get_restricted_service_criteria(serviceAreas, L_wl, 20)[5]
    else
        F_s = get_service_area_factors(serviceAreaString, L_wl, 20)[1]
	end

    M_o = 0.1 * get_l_f(L_r) * F_s * L_r^2 * B_wl * (C_b + 0.7)

    if L_r == 0
        D_f = 0
	elseif L_r > 0 && L_r <= 0.4
        D_f = linear_interpolation(L_r, 0, 0.4, 0, 1)
    elseif L_r < 0.4 && L_r > 0.65
        D_f = 1.0
	elseif L_r >= 0.65 && L_r < 1
        D_f = linear_interpolation(L_r, 0.65, 1, 1, 0)
    elseif L_r == 1
        D_f = 0
	end

    if M_o < 0
        M_w = F_fh * D_f * M_o
    else
        M_w = F_fs * D_f * M_o
	end

return M_o
end
