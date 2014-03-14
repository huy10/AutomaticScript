function overlapping = Overlap(mou,mouth)
%Compute Overlapping between two boxes
%   min:0, max: 1

cnt = 0;
for m = mou(1):mou(1)+ mou(3)
    if m > mouth(1) && m < mouth(1) + mouth(3)
        for n = mou(2) : mou(2) + mou(4)
            if n > mouth(2) && n < mouth(2) + mouth(4)
                cnt = cnt + 1;
            end
        end
    end
end

overlapping = cnt / mou(3) / mou(4);
end
