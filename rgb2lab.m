function labImage=rgb2lab(rgbImage)
    colorTransform = makecform('srgb2lab');
    labImage = applycform(rgbImage, colorTransform);
end