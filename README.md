# GodotLogger by Spooner

logger.gd is a simple logging system. It allows for more formatted logging,
logging levels and logging to a file.

The logger.gd script was written by [Spooner](https://gist.github.com/Spooner/0daff3fd31411488fe1b), the other files were added by Matthew to enable this repo to be cloned directly into the addons folder.

## Installation

Place this file somewhere (for example, 'res://root/logger.gd')
and autoload it (in project settings) to make it into a globally accessible singleton.

## Logger levels

`Level.DEBUG` - Show all log messages
`Level.INFO` - Show info(), warning(), error() and critical() log messages [DEFAULT]
`Level.WARNING` - Show warning(), error() and critical() log messages
`Level.ERROR` - Show error() and critical() log messages
`Level.CRITICAL` - Show only critical() log messages

## Time formats

    TimeFormat.NONE
    TimeFormat.DATETIME [YYYY-MM-DD HH:MM:SS.mmm]
    TimeFormat.TIME [HH:MM:SS.mmm]
    TimeFormat.ELAPSED [H:MM:SS.mmm]

## Examples

Getting a reference to the global logger object with:

    var logger = get_node('/root/logger')

Setting the logger level (default is Level.INFO):

    logger.level = logger.Level.DEBUG

Setting whether to print() message (default is to print):

    logger.print_std = false

Setting showing the current elapsed time (defaults to show TimeFormat.DATETIME):

    logger.time_format = TimeFormat.ELAPSED

Setting time formatter to use your own function (which would normally be called as 

    my_instance.time_formatter()):
        logger.time_format_func = funcref(my_instance, "time_formatter")

Logging to a file (set to 'null' to close the file):

    logger.file_name = 'user://log.txt'
    
Logging messages of various types (will use var2str() to output any non-string being logged):

    logger.info("Creating a new fish object")
    logger.debug([my_vector3, my_vector2, my_list])
    logger.warning("Tried to take over the moon!")
    logger.error("File doesn't exist, so I can't go on")
    logger.critical("Divided by an ocelot error! Segfault immanent")

## License: MIT