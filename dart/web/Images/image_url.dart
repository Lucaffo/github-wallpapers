/*
*   Image Url class.
*   
    Is responsibile to manage the full path of an image and 
*   do all the parsing part.
*   
*   Luca Raffo @ 04/02/2025
*/
class ImageUrl
{
    final String _fullPath;
    String? _basePath;
    String? _filename;
    String? _extension;

    ImageUrl(this._fullPath)
    {
        RegExp pathRegex = RegExp(r'(?<basepath>\S+)\/(?<filename>\w+).(?<ext>\w+)$');
        RegExpMatch? match = pathRegex.firstMatch(_fullPath);
        
        if(match != null)
        {
            _basePath = match.namedGroup("basepath");
            _filename = match.namedGroup("filename");
            _extension = match.namedGroup("ext");
        }
    }

    // Get the full path toward the image
    String getFullPath()
    {
        return _fullPath;
    }

    // Ge the base path of the full path
    String? getBasePath()
    {
        return _basePath;
    }

    // Get the filename, with extension if needed.
    String? getFileName(bool withExtension)
    {
        return withExtension ? '$_filename.$_extension' : _filename;
    }

    // Get the file extension
    String? getFileExtension()
    {
        return _extension;
    }
}