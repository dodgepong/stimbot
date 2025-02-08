// Description:
//   Tool for searching ANCUR's archives
//
// Commands:
//   !ancur <search term> - search ANCUR for pages related to <search term>

module.exports = (robot) => {
  robot.hear(/!ancur (.+)/i, (msg) => {
    const query = msg.match[1];
    robot.http(`http://ancur.wikia.com/api/v1/Search/List?query=${query}`)
      .get()((err, res, body) => {
        if (body) {
          const response = JSON.parse(body);
          if (response.total === 0) {
            msg.send(`No matches found on ANCUR for "${query}."`);
          } else {
            const title = response.items[0].title;
            const url = response.items[0].url;
            msg.send(`${title}: ${url}`);
          }
        }
      });
  });
};