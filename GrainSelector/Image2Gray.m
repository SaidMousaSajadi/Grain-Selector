function [Gray,M] = Image2Gray(IM,M)
  pkg load image ;
  if ndims(IM) == 2 % 2D
    if islogical(IM) % Binary ?
      Gray = IM(:,:,1) ;
    else % No-Binary
      if isempty(M) % No-ColorMap
        Gray = double(IM)/255 ;
      else % ColorMap
        RGB = ind2rgb(IM,M) ;
        Gray = rgb2gray(RGB) ;
      end
    end
  elseif ndims(IM) == 3 & size(IM,3) == 3 % 2D & 3 Channel
    if islogical(IM) % Binary
      Gray = IM(:,:,1) ;
    else % No-Binary
      if isempty(M) % No-ColorMap
        Gray = double(rgb2gray(IM))/255 ;
      else % ColorMap ?
        IM = ind2rgb(IM,M) ;
        Gray = rgb2gray(IM) ;
      end
    end
  end
end