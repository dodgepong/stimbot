module.exports = (robot) ->
    robot.hear /^test attachment/i, (msg) ->
        attachment = {
            fallback: 'test attachment',
            title: 'This is a test attachment',
            text: 'This is attachment text.'
        }
        msg.send
            attachments: [attachment]

    robot.hear /^test message/i, (msg) ->
        msg.send 'This is a test message.'
