import axios from 'axios';

async function testInnertube() {
  try {
    const res = await axios.post(
      'https://www.youtube.com/youtubei/v1/search?prettyPrint=false',
      {
        context: {
          client: {
            clientName: 'WEB',
            clientVersion: '2.20240101.00.00',
            hl: 'en',
            gl: 'IN',
          },
        },
        query: 'Honey Singh',
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        },
        timeout: 8000,
      }
    );

    console.log('Innertube status:', res.status);
    const contents =
      res.data?.contents?.twoColumnSearchResultsRenderer?.primaryContents
        ?.sectionListRenderer?.contents?.[0]?.itemSectionRenderer?.contents;

    if (contents) {
      const videos = contents
        .filter((c: any) => c.videoRenderer)
        .map((c: any) => ({
          id: c.videoRenderer.videoId,
          title: c.videoRenderer.title?.runs?.[0]?.text,
          author: c.videoRenderer.ownerText?.runs?.[0]?.text,
          length: c.videoRenderer.lengthText?.simpleText,
        }));

      console.log('Found', videos.length, 'videos!');
      console.log('Sample:', videos.slice(0, 3));
    }
  } catch (e: any) {
    console.error('Innertube error:', e.message);
  }
}

testInnertube();
