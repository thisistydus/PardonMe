"""Create separate Godot audio derivatives; never modify supplied sources."""
from pathlib import Path
import json, subprocess, sys
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools/audio-runtime'))
import imageio_ffmpeg
ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
tracks = {
 'Warranty Void.m4a': 'anvil_warranty_void.ogg',
 'Ask for the Receipt.m4a': 'backspin_ask_for_the_receipt.ogg',
 "The Devil Can't Drive My Truck.m4a": 'kbuck_the_devil_cant_drive_my_truck.ogg',
 'Airplane Mode.m4a': 'pulse_airplane_mode.ogg',
}
report=[]
for name, output in tracks.items():
 source=ROOT/'Music'/name
 destination=ROOT/'Music/Imported'/output
 subprocess.run([ffmpeg, '-hide_banner', '-loglevel', 'warning', '-nostdin', '-n', '-i', str(source), '-map', '0:a:0', '-vn', '-sn', '-c:a', 'libvorbis', '-q:a', '5', '-ar', '44100', str(destination)], check=True)
 # Decode the complete output to catch truncated or invalid audio.
 subprocess.run([ffmpeg,'-v','error','-i',str(destination),'-f','null','-'],check=True)
 report.append({'source':str(source.relative_to(ROOT)),'derived':str(destination.relative_to(ROOT)),'codec':'Vorbis','sample_rate':44100,'full_decode':'passed'})
(ROOT/'docs/radio_conversion.json').write_text(json.dumps(report,indent=2)+'\n')
