$URL = 'gdiac.cs.cornell.edu/cs4154/fall2015/get_data.php?game_id=121&version_id=' + $args[0] + '&show_html=NO'
ECHO $URL
(wget $URL).Content > info.json
.\Converter.swf info.json