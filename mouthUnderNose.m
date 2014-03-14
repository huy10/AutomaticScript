function isMouth = mouthUnderNose( mouth, nose )
%mouthUnderNose  return is the detected mouth is under nose
%  use y axis and x axis
isMouth = false;
      if mouth(2) > nose(2) + nose(4)
         % if mouth(2) < nose(2) && mouth(2)+mouth(4) > nose(2) + nose(4)
              isMouth = true;
         % end
      end
end
