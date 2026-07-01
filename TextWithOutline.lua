TextWithOutline = {}

function TextWithOutline.print(text, x, y, outline_width, color_text, color_outline, size, is_square)
    -- is_square значит, что обводка квадратная, а не круглая
    size = size or 1
    for dx = -outline_width, outline_width do
        for dy = -outline_width, outline_width do
            if is_square or dx^2 + dy^2 <= outline_width^2 then
                print(text, x+dx, y+dy, color_outline, false, size)
            end
        end
    end
    print(text, x, y, color_text, false, size)
end


-- function TextWithOutline.get_default_animation(text, x, y, outline_width, color_text, color_outline, size, is_square)

-- end

-- function TextWithOutline.update_dafault_animation(animation)
--     if animation.t == 0 then
--         animation.t = animation.T
--         if animation.is_reverse then
--             animation.outline_width = math.max(0, animation.outline_width - 1)
--         end
--     else
--         animation.t = Basic.tick_timer(animation.t)
--     end
-- end
