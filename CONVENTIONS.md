This document is the attempt to collect some rough rules for tools to follow in this repository, to facilitate their consistency and interoperability. This document is an extension to the [Naming and Annotation Conventions for Tools in the Image Community in Galaxy](https://github.com/elixir-europe/biohackathon-projects-2023/blob/main/16/paper/paper.md#conventions) and compatibility should be maintained. This document is work in progress.

## Terminology

**Intensity images.**

**Label maps** are images with pixel-level annotations, usually corresponding to distinct image regions (e.g., objects). We avoid the terms *label image* and *labeled image*, since these can be easily confused with image-level annotations (instead of pixel-level). The labels (pixel values) must uniquely identify the labeled image regions (i.e. labels must be unique, even for non-adjacent image regions). If a label semantically corresponds to the image background, that label should be 0.

**Binary images** are a special case of label maps with only two labels. To facilitate visual perception, the foreground label should correspond to white (value 255 for `uint8` images and value 65535 for `uint16` images), since background corresponds to the label 0, which is black.

## File types

Tools with **label map inputs** should accept PNG and TIFF files. If a tool wrapper only supports single-channel 2-D label maps and uses a Python script, the structure of the input should be verified right after loading the image:

```python
im = skimage.io.imread(args.input)
im = np.squeeze(im)  # remove axes with length 1
assert im.ndim == 2
```

Tools with **label map outputs** should produce either `uint16` single-channel PNG or `uint16` single-channel TIFF. Using `uint8` instead of `uint16` is also acceptable, if there definetely are no more than 256 different labels. Using `uint8` should be preferred for binary images.

## Future extensions

Below is a list of open questions:

- **How do we want to cope with multi-channel label maps?** For example, do or can we distinguish RGB labels from multi-channel binary masks, which are sometimes used to represent overlapping objects?

- How can we distinguish multi-channel 2-D images from single-channel 3-D images?

- How can we make clear to the user, whether a tool requires a 2-D image or also supports 3-D?
