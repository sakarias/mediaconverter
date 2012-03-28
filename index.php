<?php
	header ("Content-type: application/rss+xml");
	print "<?xml version=\"1.0\" encoding=\"UTF-8\"?> \n";
?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
<channel>
	<title>Sakarias iPhone/iPad TV-series feed</title>
	<link>http://gongo.local/podcast/</link>
	<language>en-us</language>
	<copyright>&#xA9; Sakarias</copyright>
	<itunes:subtitle>Sakarias iPhone/iPad TV-series feed.</itunes:subtitle>
	<itunes:author>Sakarias</itunes:author>
	<itunes:summary>Sakarias iPhone/iPad TV-series feed.</itunes:summary>
	<description>Sakarias iPhone/iPad TV-series feed.</description>
	<itunes:owner>
		<itunes:name>Sakarias</itunes:name>
		<itunes:email>sakarias@gmail.com</itunes:email>
	</itunes:owner>
	<itunes:image href="http://gongo.local/podcast/images/filmcamera.png" />
	<itunes:category text="TV &amp; Film" />
<?php
	$dir = "/var/www/podcast/rss/";
	if (is_dir($dir)) {
		if ($dh = opendir($dir)) {
		while (($file = readdir($dh)) !== false) {
			if (filetype($dir.$file) == "file") {
				include("$dir/$file");
			}
		}
		closedir($dh);
		}
	}
	?>
</channel>
</rss>
