    This Python script will display a calendar of the current month in Conky. Call it in conky by using ${execpi <interval in seconds> python /path/to/cal.py}. You may have to edit/delete the "${offset}" variables in the following line to make it display just right:


cal = '${alignc}${offset -8}' + '\n${offset 37}'.join(parts)

    Besides that, if you want to edit the colors just find all the instances of "${color" and edit them to your liking. Happy scripting! }
