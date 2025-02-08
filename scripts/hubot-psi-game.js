// Description:
//   Play a psi game.
//
// Commands:
//   !psi [0, 1, or 2] - play a psi game against stimbot

module.exports = (robot) => {
  robot.hear(/^!psi (\d+)\s*$/i, (res) => {
    const bid = parseInt(res.match[1]);
    if ([0, 1, 2].includes(bid)) {
      const myBid = Math.floor(Math.random() * 3);
      let win = "I win!";
      if (bid === myBid) {
        win = "you win!";
      }
      res.send(`:psi: Your bid: ${bid}:credit:, my bid: ${myBid}:credit:, ${win}`);
    } else {
      res.send(":psi: Hey, that's an illegal bid, cheater!");
    }
  });
};