import React, { useEffect, useState } from 'react';
import { Card, Image, Media } from 'react-bootstrap';

type Props = {
  searchTerm: string;
};

type ItunesSearchResult = {
  results: {
    trackViewUrl: string;
  }[];
};

export const ItunesAd: React.FC<Props> = ({ searchTerm }: Props) => {
  const [itunesSearchResult, setItunesSearchResult] = useState<ItunesSearchResult | null>(null);

  useEffect(() => {
    (async () => {
      // https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
      const itunesSearchParams = new URLSearchParams();
      itunesSearchParams.append('term', searchTerm);
      itunesSearchParams.append('country', 'JP');
      itunesSearchParams.append('media', 'music');
      itunesSearchParams.append('entity', 'song');
      itunesSearchParams.append('limit', '1');
      itunesSearchParams.append('lang', 'ja_jp');

      const itunesSearchURL = new URL('https://itunes.apple.com/search');
      itunesSearchURL.search = itunesSearchParams.toString();

      const response = await fetch(itunesSearchURL.toString());
      if (!response.ok) {
        throw new Error(`Failed GET ${itunesSearchURL} (${response.status} ${response.statusText})`);
      }

      const searchResult = await response.json();
      setItunesSearchResult(searchResult);
    })();
  }, [searchTerm]);

  if (itunesSearchResult === null || itunesSearchResult.results.length === 0) {
    return null;
  }

  // https://affiliate.itunes.apple.com/resources/documentation/basic_affiliate_link_guidelines_for_the_phg_network/
  // https://tools.applemediaservices.com/
  const affiliateEmbedSrc = new URL(itunesSearchResult.results[0].trackViewUrl);
  affiliateEmbedSrc.hostname = 'embed.music.apple.com';
  affiliateEmbedSrc.searchParams.append('app', 'music');
  affiliateEmbedSrc.searchParams.append('at', '1001lKQU');

  return (
    <div className="mb-3">
      <iframe
        src={affiliateEmbedSrc.toString()}
        height="150px"
        frameBorder="0"
        sandbox="allow-forms allow-popups allow-same-origin allow-scripts allow-top-navigation-by-user-activation"
        allow="autoplay *; encrypted-media *;"
        style={{
          width: '100%',
          overflow: 'hidden',
          borderRadius: '10px',
          background: 'transparent',
        }}
      ></iframe>
    </div>
  );
};
