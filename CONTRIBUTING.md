# Contributing

This document is the attempt to collect some rough rules for tools to follow in this repository, to facilitate their consistency and interoperability. This document is an extension to the [Naming and Annotation Conventions for Tools in the Image Community in Galaxy](https://github.com/elixir-europe/biohackathon-projects-2023/blob/main/16/paper/paper.md#conventions) and compatibility should be maintained. This document is work in progress.

**How to Contribute:**

* Make sure you have a [GitHub account](https://github.com/signup/free)
* Make sure you have git [installed](https://help.github.com/articles/set-up-git)
* Fork the repository on [GitHub](https://github.com/BMCV/galaxy-image-analysis/fork)
* Make the desired modifications - consider using a [feature branch](https://github.com/Kunena/Kunena-Forum/wiki/Create-a-new-branch-with-git-and-manage-branches).
* Try to stick to the [Conventions for Tools in the Image Community](https://github.com/elixir-europe/biohackathon-projects-2023/blob/main/16/paper/paper.md#conventions) and the [IUC standards](http://galaxy-iuc-standards.readthedocs.org/en/latest/) whenever you can
* Make sure you have added the necessary tests for your changes and they pass.
* Open a [pull request](https://help.github.com/articles/using-pull-requests) with these changes.

## Terminology

**Label maps** are images with pixel-level annotations, usually corresponding to distinct image regions (e.g., objects). We avoid the terms *label image* and *labeled image*, since these can be easily confused with image-level annotations (instead of pixel-level). The labels (pixel values) must uniquely identify the labeled image regions (i.e. labels must be unique, even for non-adjacent image regions). If a label semantically corresponds to the image background, that label should be 0.

**Binary images** are a special case of label maps with only two labels (e.g., image background and image foreground). To facilitate visual perception, the foreground label should correspond to white (value 255 for `uint8` images and value 65535 for `uint16` images), since background corresponds to the label 0, which is black.

**Intensity images** are images which are *not* label maps (and thus neither binary images).

## File types

If a tool wrapper only supports single-channel 2-D images and uses a Python script, the structure of the input should be verified right after loading the image:

```python
im = skimage.io.imread(args.input)
im = np.squeeze(im)  # remove axes with length 1
assert im.ndim == 2
```

Tools with **label map inputs** should accept PNG and TIFF files. Tools with **label map outputs** should produce either `uint16` single-channel PNG or `uint16` single-channel TIFF. Using `uint8` instead of `uint16` is also acceptable, if there definetely are no more than 256 different labels. Using `uint8` should be preferred for binary images.

> [!NOTE]  
> It is a common misconception that PNG files must be RGB or RGBA, and that only `uint8` pixel values are supported. For example, the `cv2` module (OpenCV) can be used to create single-channel PNG files, or PNG files with `uint16` pixel values. Such files can then be read by `skimage.io.imread` without issues (however, `skimage.io.imwrite` seems not to be able to write such PNG files).

Tools with **intensity image inputs** should accept PNG and TIFF files. Tools with **intensity image outputs** can be any data type and either PNG or TIFF. Image outputs meant for visualization (e.g., segmentation overlays, charts) should be PNG.

## Testing

For testing of **binary image outputs** we recommend using the `mae` metric (mean absolute error). With the default value of `eps` of 0.01, this asserts that at most 1% of the image pixels are labeled differently:

```xml
<output name="output" value="output.tiff" ftype="tiff" compare="image_diff" metric="mae">
    <assert_contents>
        <has_image_n_labels n="2"/>
    </assert_contents>
</output>
```

For testing of non-binary **label map outputs** with interchangeable labels, we recommend using the `iou` metric (one minus the intersection over the union). At the moment it is not possible to *pin* specific labels, for example to verify that the background is assigned the correct label, but this will hopefully be added in the future:

```xml
<output name="output" value="output.tiff" ftype="tiff" compare="image_diff" metric="iou"/>
```

For testing of **intensity image outputs** we recommend the `rms` metric (root mean square), because it is very sensitive to large pixel value differences, but tolerates smaller differences.

```xml
<output name="output" value="output.tiff" ftype="tiff" compare="image_diff" metric="rms"/>
```

## Future extensions

Below is a list of open questions:

- **How do we want to cope with multi-channel label maps?** For example, do or can we distinguish RGB labels from multi-channel binary masks, which are sometimes used to represent overlapping objects?

- How can we distinguish multi-channel 2-D images from single-channel 3-D images?

- How can we make clear to the user, whether a tool requires a 2-D image or also supports 3-D?
