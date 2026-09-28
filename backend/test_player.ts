import axios from 'axios';

async function testPlayer(videoId: string) {
  try {
    const res = await axios.post(
      'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
      {
        context: {
          client: {
            clientName: 'ANDROID',
            clientVersion: '19.09.37',
            androidSdkVersion: 34,
            hl: 'en',
            gl: 'IN',
          },
        },
        videoId: videoId,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'com.google.android.youtube/19.09.37 (Linux; U; Android 14; en_US) gzip',
        },
        timeout: 10000,
      }
    );

    console.log('Player status:', res.status);
    const streamingData = res.data?.streamingData;
    if (streamingData) {
      const formats = [...(streamingData.formats || []), ...(streamingData.adaptiveFormats || [])];
      console.log('Total formats:', formats.length);
      const audioFormats = formats.filter((f: any) => f.mimeType?.includes('audio'));
      console.log('Audio formats:', audioFormats.length);
      for (const af of audioFormats.slice(0, 3)) {
        console.log({
          itag: af.itag,
          mimeType: af.mimeType,
          bitrate: af.bitrate,
          hasUrl: !!af.url,
          urlSample: af.url ? af.url.substring(0, 60) + '...' : 'NO DIRECT URL (cipher)',
        });
      }
    } else {
      console.log('Playability status:', res.data?.playabilityStatus);
    }
  } catch (e: any) {
    console.error('Player error:', e.message);
  }
}

testPlayer('TwFBtV13KQQ'); // Yo Yo Honey Singh - One Bottle Down
