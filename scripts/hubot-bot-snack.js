// Description:
//   Give stimbot a snack.
//
// Commands:
//   stimbot bot snack - Give stimbot a snack

module.exports = (robot) => {
  robot.hear(/bot snack/i, (res) => {
    robot.logger.debug("Snack time!");
    res.send("Yum!");
  });
};