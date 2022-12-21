package src;

import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import sys.FileSystem;
import sys.io.File;
import JsonFormat.Arc;
import JsonFormat.Entry;
import JsonFormat.Group;

class Main
{
	static function main()
	{
		var json:Arc = Json.parse(File.getContent("arc.json"));
		var pack:Bytes = File.getBytes("arc.pack");

		if (pack != null)
		{
			for (i in 0...json.Groups.length)
			{
				var group:Group = json.Groups[i];
				var basePath:String = 'data/${group.Name}';

				FileSystem.createDirectory(basePath);
	
				for (j in 0...group.OrderedEntries.length)
				{
					var entry:Entry = group.OrderedEntries[j];
					var filename:String = entry.OriginalFilename;
					var offset:Int = entry.Offset;
					var length:Int = entry.Length;

					var filePath:String = '$basePath/$filename';
					FileSystem.createDirectory(filePath.substr(0, filePath.lastIndexOf("/")));
	
					var data:BytesInput = new BytesInput(pack, offset, length);
					File.saveBytes(filePath, data.readAll());
				}
			}
		}
		else
		{
			trace("arc.pack doesn't exist!");
		}
	}
}
