# Music Migration Automation Plan

## Overview

Automate the migration of owned music from Apple Music and Spotify to the local music library using existing `ytdl` and `music-organize` tools.

## Goals

1. Export music libraries from Apple Music and Spotify
2. Create unified, deduplicated track/album list
3. Batch download via YouTube with `ytdl`
4. Auto-organize using existing AI-powered system
5. Minimize manual intervention while ensuring quality

## Data Sources

### Apple Music Export
- **Method**: iTunes/Music app → File → Library → Export Library (XML)
- **Data Available**:
  - Track name, artist, album, genre
  - Play count, rating, date added
  - File location (for owned music)
  - Track duration, bit rate
- **Filtering**: Only include owned music (exclude Apple Music streaming)

### Spotify Export
- **Method**: Official data export (Account → Privacy → Download data)
  - Takes up to 30 days but comprehensive and reliable
  - Includes saved tracks, playlists, listening history
  - No API credentials needed
  - Complete JSON/CSV export of personal library

## Implementation Architecture

### Simple Script Approach (One-Time Use)

Since this is a one-time migration, we'll create simple, focused scripts:

### Step 1: Parse Apple Music (`parse-apple-music.py`)
```bash
./parse-apple-music.py ~/Music/iTunes\ Music\ Library.xml > apple-music.json
```
- Extract owned tracks only (skip Apple Music streaming)
- Output: JSON with artist, album, track, duration, genre, play count

### Step 2: Parse Spotify Export (`parse-spotify.py`)
```bash
./parse-spotify.py ~/Downloads/spotify-export/ > spotify.json
```
- Parse saved tracks, liked songs, playlists
- Output: Same JSON format as Apple Music

### Step 3: Combine & Dedupe (`combine-libraries.py`)
```bash
./combine-libraries.py apple-music.json spotify.json > unified-library.json
```
- Merge both libraries
- Remove duplicates using fuzzy matching
- Output: Deduplicated unified library

### Step 4: YouTube Search (`search-youtube.py`)
```bash
./search-youtube.py unified-library.json > download-queue.json
```
- Use YouTube Data API v3 for searches
- Album-first approach, fallback to individual tracks
- Generate download URLs with confidence scores

### Step 5: Batch Download (`download-batch.sh`)
```bash
./download-batch.sh download-queue.json
```
- Loop through URLs calling your existing `ytdl` script
- Built-in delays to avoid rate limiting
- Resume capability

### Step 6: Manual Review & Organization
- Use existing `music-organize` tool for final placement
- Review any low-confidence matches manually

## Technical Implementation

### Script Directory Structure
```
~/migration-scripts/
├── parse-apple-music.py      # Parse iTunes XML library
├── parse-spotify.py          # Parse Spotify export data
├── combine-libraries.py      # Merge and deduplicate
├── search-youtube.py         # YouTube Data API search
├── download-batch.sh         # Batch download with ytdl
├── requirements.txt          # Python dependencies
└── config.json              # API keys and settings
```

### Data Structures

**Unified Track Format**:
```json
{
  "id": "uuid",
  "title": "Track Name",
  "artist": "Artist Name", 
  "album": "Album Name",
  "duration": 240,
  "sources": ["apple-music", "spotify"],
  "metadata": {
    "genre": "Rock",
    "year": 2023,
    "play_count": 15,
    "rating": 5
  }
}
```

**Download Queue Format**:
```json
{
  "id": "uuid",
  "search_query": "Artist - Album",
  "search_type": "album|track",
  "youtube_url": "https://...",
  "confidence_score": 0.95,
  "expected_tracks": 12
}
```

## Dependencies

### Required Tools
- `yt-dlp` (already available)
- `eyeD3` (already available)
- `jq` (JSON processing)
- `fzf` (interactive selection)
- `curl` (API calls)

### New Dependencies
- Python libraries for XML parsing (`xmltodict`, `lxml`)
- Fuzzy string matching library (`fuzzywuzzy`)
- JSON/CSV parsing libraries (built-in `json`, `csv`)

### API Requirements
- **YouTube Data API v3 key** (required, free 10,000 units/day)
- **Spotify manual export** (no API credentials needed)

## Risk Mitigation

### Download Quality
- **Problem**: YouTube quality varies
- **Solution**: Prefer YouTube Music, check audio quality, user review step

### Rate Limiting
- **Problem**: YouTube Data API may throttle requests (10,000 units/day limit)
- **Solution**: Configurable delays, exponential backoff, resume capability, batch processing

### Storage Space
- **Problem**: Could download hundreds of albums
- **Solution**: Disk space check, progressive download, user confirmation

### False Matches
- **Problem**: Wrong songs downloaded
- **Solution**: Confidence scoring, manual review mode, sample previews

## User Experience

### Interactive Mode
```bash
music-migrate --interactive
# Shows preview of what will be downloaded
# Allows manual review of uncertain matches
# Provides progress tracking
```

### Dry Run Mode
```bash
music-migrate --dry-run
# Shows what would be downloaded without doing it
# Estimates storage requirements
# Identifies potential issues
```

### Progress Tracking
- Real-time download progress
- ETA calculations
- Success/failure statistics
- Detailed logging

## Configuration

### Config File: `~/migration-scripts/config.json`
```json
{
  "youtube_api_key": "YOUR_API_KEY_HERE",
  "sources": {
    "apple_music_xml": "~/Music/iTunes Music Library.xml",
    "spotify_export_dir": "~/Downloads/spotify-export/"
  },
  "search": {
    "delay_between_searches": 1,
    "max_results_per_search": 10,
    "confidence_threshold": 0.7
  },
  "download": {
    "batch_size": 10,
    "delay_between_downloads": 5,
    "output_dir": "~/pCloud Drive/02_AREAS/Music/Inbox"
  },
  "matching": {
    "fuzzy_threshold": 0.8,
    "duration_tolerance": 0.1
  }
}
```

## Testing Strategy

### Step-by-Step Testing
1. **Parse Apple Music**: Test with small XML subset
2. **Parse Spotify**: Test with sample export data
3. **Combine & Dedupe**: Test with known duplicates
4. **YouTube Search**: Test with 5-10 known tracks
5. **Download**: Test batch download with 2-3 URLs
6. **Full Pipeline**: Run complete process with 20-30 tracks

### Edge Cases
- Tracks not available on YouTube
- Albums with missing tracks
- Different album versions (deluxe, remastered)
- Classical music with complex metadata
- Podcasts mixed with music

## Success Metrics

### Quantitative
- **Match Rate**: >90% of tracks found on YouTube
- **Quality Rate**: >95% correct downloads
- **Performance**: <2 seconds per search, <5 minutes per album download

### Qualitative
- User satisfaction with automation level
- Accuracy of final organization
- Time saved vs. manual process

## Future Enhancements

### Advanced Features
- **Smart Playlists**: Recreate playlists from exports
- **Metadata Enhancement**: Use MusicBrainz for better metadata
- **Quality Verification**: Audio fingerprinting to verify downloads
- **Streaming Integration**: Keep links to streaming versions

### Integration Opportunities
- **Last.fm**: Import scrobble data
- **Discogs**: Enhanced metadata and collection management
- **Plex/Jellyfin**: Auto-update media servers

## Implementation Timeline

### Phase 1: Data Parsing (1-2 days)
- Create `parse-apple-music.py` - Extract owned tracks from XML
- Create `parse-spotify.py` - Parse export data structure
- Test with small datasets

### Phase 2: Deduplication (1 day)
- Create `combine-libraries.py` - Merge and dedupe
- Test fuzzy matching accuracy
- Fine-tune matching thresholds

### Phase 3: Search & Download (2-3 days)
- Set up YouTube Data API v3 access
- Create `search-youtube.py` - API-powered search
- Create `download-batch.sh` - Batch downloader
- Test with small batches

### Phase 4: Full Migration (1-2 days)
- Run complete pipeline on full library
- Manual review of uncertain matches
- Use `music-organize` for final placement

## Risk Assessment

### High Risk
- **API Changes**: Spotify/YouTube APIs may change
- **Rate Limiting**: Could slow down or block process
- **Legal Concerns**: Ensure compliance with ToS

### Medium Risk
- **Quality Issues**: Some downloads may be poor quality
- **Storage Requirements**: Could use significant disk space
- **Metadata Accuracy**: Some tracks may be misidentified

### Low Risk
- **Technical Issues**: Can be resolved through testing
- **User Experience**: Can be improved iteratively

## Conclusion

This migration automation will significantly reduce the manual effort required to move music libraries while leveraging the existing robust `ytdl` and `music-organize` infrastructure. The phased approach allows for testing and refinement at each stage, while the modular design enables future enhancements and integration with other music management tools.