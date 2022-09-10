# GodotLogger by Spooner
# ======================
#
# logger.gd is a simple logging system. It allows for more formatted logging,
# logging levels and logging to a file.
#
# Installation
# ------------
#
#     Place this file somewhere (for example, 'res://root/logger.gd')
#     and autoload it (in project settings) to make it into a globally accessible singleton.
#
# Logger levels
# -------------
#
#     Level.DEBUG - Show all log messages
#     Level.INFO - Show info(), warning(), error() and critical() log messages [DEFAULT]
#     Level.WARNING - Show warning(), error() and critical() log messages
#     Level.ERROR - Show error() and critical() log messages
#     Level.CRITICAL - Show only critical() log messages
#
# Time formats
# ------------
#
#     TimeFormat.NONE
#     TimeFormat.DATETIME [YYYY-MM-DD HH:MM:SS.mmm]
#     TimeFormat.TIME [HH:MM:SS.mmm]
#     TimeFormat.ELAPSED [H:MM:SS.mmm]
#
# Examples
# --------
#
#     Getting a reference to the global logger object with:
#         var logger = get_node('/root/logger')
# 
#     Setting the logger level (default is Level.INFO):
#         logger.level = logger.Level.DEBUG
#
#     Setting whether to print() message (default is to print):
#         logger.print_std = false
#
#     Setting showing the current elapsed time (defaults to show TimeFormat.DATETIME):
#         logger.time_format = TimeFormat.ELAPSED
#
#     Setting time formatter to use your own function (which would normally be called as my_instance.time_formatter()):
#         logger.time_format_func = funcref(my_instance, "time_formatter")
#
#     Logging to a file (set to 'null' to close the file):
#         logger.file_name = 'user://log.txt'
#        
#     Logging messages of various types (will use var2str() to output any non-string being logged):
#         logger.info("Creating a new fish object")
#         logger.debug([my_vector3, my_vector2, my_list])
#         logger.warning("Tried to take over the moon!")
#         logger.error("File doesn't exist, so I can't go on")
#         logger.critical("Divided by an ocelot error! Segfault immanent")
#
# License: MIT
extends Node

# Levels of debugging available
enum Level { DEBUG = 0, INFO = 1, WARNING = 2, ERROR = 3, CRITICAL = 4 }

# Built in time formatters
enum TimeFormat { NONE = 0, ELAPSED = 1, TIME = 2, DATETIME = 3 }


func _ready():
	if $"/root".has_node("Console"):
		Console.add_command("set_print_level", self, 'set_level')\
				.set_description("Sets the output level for printing. Debug level is the most verbose. " +\
					"Each level contains the levels above.")\
				.add_argument("Level", typeof(1), "Debug = 0, Info = 1, Warning = 2, Error = 3, Critical = 4")\
				.register()


# Print to stdout?
var print_stdout = true setget set_print_stdout, get_print_stdout
func get_print_stdout():
	return print_stdout
func set_print_stdout(value):
	assert(value in [true, false])
	print_stdout = value


# Logging level.
var level = Level.INFO setget set_level, get_level
func get_level():
	return level
func set_level(value):
	assert(level in [Level.DEBUG, Level.INFO, Level.WARNING, Level.ERROR, Level.CRITICAL])
	level = value


# Logging to file.
var file = null
var file_name = null setget set_filename, get_filename
func get_filename():
	return file_name
func set_filename(value):
	if file != null:
		info("Stopped logging to file: %s" % file_name)
		file.close()

	if value != null:
		file = File.new()
		file_name = value
		file.open(file_name, File.WRITE)
		info("Started logging to file: %s" % file_name)
	else:
		file = null
		file_name = null  

# Log timer
var time_format_func = funcref(self, "format_time_datetime") setget set_time_format_func
func set_time_format_func(value):
	time_format_func = value


var time_format = TimeFormat.DATETIME setget set_time_format
func set_time_format(value):
	if value == TimeFormat.NONE:
		self.time_format_func = funcref(self, "format_time_none")
	elif value == TimeFormat.DATETIME:
		self.time_format_func = funcref(self, "format_time_datetime")
	elif value == TimeFormat.TIME:
		self.time_format_func = funcref(self, "format_time_time")
	elif value == TimeFormat.ELAPSED:
		self.time_format_func = funcref(self, "format_time_elapsed")
	else:
		assert(false) # Bad time format used.


# --- Time formatters for use by the logger.
func format_time_none():
	return ""


func format_time_elapsed():
	return "[%s] " % _format_elapsed()


func format_time_time():
	return "[%s] " % _format_time()


func format_time_datetime():
	return "[%s %s] " % [_format_date(), _format_time()]


# --- General time formatting functions
func _format_time():
	"""Not used directly, but might come in useful"""
	var time = OS.get_time()
	# This is not "correct", but gives impression of ms moving on!
	var ms = OS.get_ticks_msec() % 1000

	return "%02d:%02d:%02d.%03d" % [time["hour"], time["minute"], time["second"], ms]


func _format_elapsed():
	"""Not used directly, but might come in useful"""
	var time = OS.get_ticks_msec()
	var ms = time % 1000
	var s = int(time / 1000) % 60
	var m = int(time / 60000) % 60
	var h = int(time / 3600000)

	return "%d:%02d:%02d.%03d " % [h, m, s, ms]


func _format_date():
	"""Not used directly, but might come in useful"""
	var date = OS.get_date()

	return "%d-%02d-%02d" % [date["year"], date["month"], date["day"]]


# --- Message writing methods
func debug(data):
	"""Debugging message"""
	if level == Level.DEBUG:
		_write(Level.DEBUG, 'DEBUG:', data)


func info(data):
	"""Informational message"""
	if level <= Level.INFO:
		_write(Level.INFO, 'INFO:', data)


func warning(data):
	"""Warning message"""
	if level <= Level.WARNING:
		_write(Level.WARNING, 'WARN:', data)


func error(data):
	"""Error message"""
	if level <= Level.ERROR:
		_write(Level.ERROR, 'ERROR:', data)


func critical(data):
	"""Critical error message"""
	_write(Level.CRITICAL, 'CRIT:', data)


func _write(lvl, typef, data):
	"""Actually write out the message string"""
	if typeof(data) != TYPE_STRING:
		data = var2str(data)

	var message = '%s%5s %s' % [time_format_func.call_func(), typef, data]

	if print_stdout:
		if $"/root".has_node("Console"):
			Console.call_deferred("write_line", message)
		else:
			if lvl == Level.CRITICAL:
				assert(false, message)
				printerr(message)
				print_stack()
			elif lvl == Level.ERROR:
				push_error(message)
				printerr(message)
			elif lvl == Level.WARNING:
				push_warning(message)
				printerr(message)
			else:
				print(message)
		
	if file != null:
		file.store_line(message)
