module.exports = (robot) ->
    robot.hear /^test attachments$/i, (msg) ->
        attachment = {
            fallback: 'a test attachment',
            title: 'This is a test attachment',
            text: 'This is attachment text.'
        }
        msg.send
            attachments: [attachment]

    robot.hear /^test messages$/i, (msg) ->
        msg.send 'This is a test message.'
