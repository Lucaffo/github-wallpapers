
# Documentation

Sample Configuration

```json
{
  "width": 3440,
  "height": 1440,
  "logos": [
    {
      "type": "logo",
      "name": "logo",
      "size": 0.6,
      "position": {
        "x": 0.5,
        "y": 0.4
      },
      "color": "rgba(255, 255, 255, 0.8)"
    }
  ],
  "background": {
    "color": "rgba(255, 255, 255, 1)",
    "name": "earth",
    "src": null
  }
}
```

> P.S. parameters with no specification are considered required!

### Main parameters
**width** (*required*)<br>
Wallpaper width

**height** (*required*)<br> 
Wallpaper height

### Background (optional)
The background is the first layer that is processed by the generator. Is totally optional, without it's displayed transparent.

**color** *(optional, default black)* <br> 
Background color.

**src** *(optional, default null)* <br> 
Background source. An URL toward an image (keep an eye on [cors](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS/Errors))

**name** *(optional, default null)* <br>
Background name. This is fetched from a collection of [backgrounds](https://github.com/Lucaffo/github-wallpapers/tree/main/static/backgrounds) using the file name. The research is smart (even with less chars) and case-insensitive.

### Logos (optional)
You can have one or more logos inside the a list of logos. No logo is displayed if leaved blank.

**type** *(optional, default null)* <br>
Logo target collection when using the **name** parameter. 
Two available collections: [logo](https://github.com/Lucaffo/github-wallpapers/tree/main/static/logos) and [octocats](https://github.com/Lucaffo/github-wallpapers/tree/main/static/octocats).

**name** *(optional, default null)* <br>
Logo name. This is fetched from the target collection using the file name. The research is smart (even with less chars) and case-insensitive.

**size** *(optional, default 1.0)* <br> 
Logo size. It multiply the image size by a factor.

**position** *(optional, default {x: 0.5, y: 0.5})* <br> 
Logo position. The position is relative to the center of the canvas. (0, 0) is top-left.

**color** *(optional, default white)* <br> 
Logo color.

