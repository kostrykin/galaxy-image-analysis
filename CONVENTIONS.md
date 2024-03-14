This document is the attempt to collect some rough rules for tools to follow in this repository, to facilitate consistency and interoperability of our tools. This document is an extension to the [Naming and Annotation Conventions for Tools in the Image Community in Galaxy](https://github.com/elixir-europe/biohackathon-projects-2023/blob/main/16/paper/paper.md#conventions) and compatibility should be maintained. This document is work in progress.

## Types of images

Intensity images.

Label maps. Labels must uniquely identify objects (i.e. labels must be unique even if objects are not adjacent).

## File types

Tools with **label map inputs** should accept PNG and TIFF files. If a tool only supports single-channel 2-D label maps, the structure of the input should be verified right after loading the image:

```python
im = skimage.io.imread(args.input)
im = np.squeeze(im)  # remove axes with length 1
assert im.ndim == 2
```

Tools with **label map outputs** should produce either `uint16` single-channel PNG or `uint16` single-channel TIFF. Using `uint8` instead of `uint16` is also acceptable, if there definetely are no more than 256 different labels.

## Future extensions

Below is a list of open questions:

- How do we want to cope with multi-channel label maps?

- How can we distinguish multi-channel 2-D images and single-channel 3-D images?

- How can we make clear to the user, whether a tool requires a 2-D image or also supports 3-D?