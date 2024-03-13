import argparse

import numpy as np
import skimage.io
import tifffile


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('input', type=str)
    parser.add_argument('bg_label', type=int)
    parser.add_argument('output', type=str)
    args = parser.parse_args()

    im = skimage.io.imread(args.input)
    im = (im != args.bg_label)
    im = (im * 255).astype(np.uint8)
    tifffile.imwrite(args.output, im)
