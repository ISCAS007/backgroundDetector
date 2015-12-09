function value=linecrosspoint(xa,xb,xc,xd)
% line (xa,xc) cross line (xb,xd)
    left=[xa(2)-xc(2),xc(1)-xa(1);xb(2)-xd(2),xd(1)-xb(1)];
    right=[xc(1)*xa(2)-xc(2)*xa(1);xd(1)*xb(2)-xd(2)*xb(1)];
    value=left\right;
    value=value';
end