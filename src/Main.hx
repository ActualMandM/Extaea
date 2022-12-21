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
		if (!FileSystem.exists("arc.json"))
		{
			var packAmt:Int = 0;

			while (FileSystem.exists('arc_$packAmt.json'))
			{
				extractData(packAmt);
				packAmt++;
			}

			if (packAmt == 0)
			{
				printError("arc.json");
				return;
			}
		}
		else
		{
			extractData();
		}
	}

	static function extractData(?packNum:Int)
	{
		var arc:String = "arc";
		if (packNum != null) arc += '_$packNum';

		if (!FileSystem.exists('$arc.json'))
		{
			printError('$arc.json');
			return;
		}

		if (!FileSystem.exists('$arc.pack'))
		{
			printError('$arc.pack');
			return;
		}

		var json:Arc = Json.parse(File.getContent('$arc.json'));
		var pack:Bytes = File.getBytes('$arc.pack');

		Sys.println('Extracting $arc.pack...');

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

	static function printError(fileName:String)
	{
		Sys.println('$fileName doesn\'t exist! Please make sure that it exists within the same directory as this executable.');
	}
}
