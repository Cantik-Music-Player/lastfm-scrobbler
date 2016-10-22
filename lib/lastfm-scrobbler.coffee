Lastfm = require 'simple-lastfm'

module.exports =
class LastfmScrobbler
  constructor: (@cantik) ->
    @username = @cantik.pluginManager.plugins.settings.addSetting('Last.fm',
                                                                  'Username',
                                                                  'text', '')
    @password = @cantik.pluginManager.plugins.settings.addSetting('Last.fm',
                                                                  'Password',
                                                                  'password', '')

    if @username != '' and @password != ''
      do @connect

    @cantik.pluginManager.plugins.settings.on('Last.fm-Username-change', (username) =>
      @username = username
      do @connect)

    @cantik.pluginManager.plugins.settings.on('Last.fm-Password-change', (password) =>
      @password = password
      do @connect)

    @cantik.pluginManager.plugins.player.on('track_changed', (track) =>
      @currentTrack = track
      @scrobble = false
      @scrobbleNowPlayingTrack(track.metadata.artist[0], track.metadata.title))

    @cantik.pluginManager.plugins.player.on('duration_change', (duration) =>
      @currentTrackDuration = duration)

    @cantik.pluginManager.plugins.player.on('current_time_change', (currentTime) =>
      if currentTime / @currentTrackDuration > 0.5 and not @scrobble
        @scrobble = true
        @scrobbleTrack(@currentTrack.metadata.artist[0],
                       @currentTrack.metadata.title))

  activate: (state) ->

  deactivate: ->

  serialize: ->

  connect: ->
    @lastfm = new Lastfm({
      api_key: '679472ce464ecfadc3d3a099649e0545',
      api_secret: '1024a74f7846ed0fcfe6cdbfb2289452',
      username: @username,
      password: @password
    })

    @lastfm.getSessionKey((result) =>
      @sessionKey = result.session_key)

  scrobbleNowPlayingTrack: (artist, title) ->
    if @sessionKey?
      @lastfm.scrobbleNowPlayingTrack({
        artist: artist,
        track: title
      })

  scrobbleTrack: (artist, title) ->
    if @sessionKey?
      @lastfm.scrobbleTrack({
        artist: artist,
        track: title
      })
