# Description:
#   Tool for notifying a chat room of changes to the FFG Upcoming page.
#
# Commands:
#	!upcoming - Displays a list of all upcoming Netrunner products.

REFRESH_FREQUENCY = 60000 # 1 min

products_match = (product1, product2) ->
	return product1.expected_by == product2.expected_by and product1.last_updated == product2.last_updated and product1.name == product2.name and product1.price == product2.price

module.exports = (robot) ->
	if process.env.ENABLE_UPCOMING_CHECKER is 'true'
		robot.logger.info "Enabling FFG Upcoming Checker"
		setInterval () ->
			url = 'https://ffgupcomingapi.herokuapp.com/?root_collection=Android:%20Netrunner%20The%20Card%20Game'
			upcoming_products = robot.brain.get('upcoming_products')
			if !upcoming_products?
				upcoming_products = {}
			robot.http(url)
				.header('Accept', 'application/json')
				.get() (err, res, body) ->
					if err
						robot.logger.error 'Error retrieving Upcoming list from FFG Upcoming API'
						return
					if res.statusCode isnt 200 and res.statusCode isnt 304
						robot.logger.error "Received bad status code #{res.statusCode} while trying to retrieve Upcoming list from FFG Upcoming API"
						return
					response = JSON.parse(body)
					if response?.results
						update_channel = false
						update_message = "Detected new changes to FFG Upcoming page for Android: Netrunner:"
						for new_product in response.results
							if new_product.product not of upcoming_products
								update_message += "\n* New product added! \"#{new_product.product}\" (#{new_product.name}) - <http://www.fantasyflightgames.com#{new_product.product_url}|More Info>"
								update_channel = true
								continue

							old_product = upcoming_products[new_product.product]
							if not products_match(old_product, new_product)
								changes = []
								if old_product.name is not new_product.name
									changes.push "Status changed to #{new_product.name}"
								if old_product.expected_by is not new_product.expected_by
									changes.push "Publish date changed to #{Date.parse(new_product.expected_by).toLocaleDateString()}"
								if old_product.price is not new_product.price
									changes.push "Price changed to $#{new_product.price}"
								update_message += "\n* #{new_product.product} updated: #{changes.join(', ')}"
								update_channel = true
								continue

						# Notify channel of any changes
						if update_channel
							robot.logger.info "Notifying of new FFG product updates"
							robot.messageRoom process.env.FFG_UPCOMING_CHECKER_ROOM, update_message

						# overwrite previous data with new data of all currently-live streams
						robot.brain.set 'upcoming_products', response.results
		, REFRESH_FREQUENCY
	else
		robot.logger.info "Disabling FG Upcoming Checker"

	robot.hear /!testupcoming?/i, (msg) ->
		command = msg.match[1]
		if process.env.ENABLE_UPCOMING_CHECKER isnt 'true'
			msg.send "The FFG Upcoming bot is offline right now. You can see all upcoing FFG products here: https://www.fantasyflightgames.com/en/upcoming/"
		else
			products = robot.brain.get('upcoming_products')
			if !products?
				products = {}
			num_products = Object.keys(products).length
			if products is 0
				msg.send "There are no known upcoming products for Android: Netrunner. :("
			else
				message = "Upcoming Android: Netrunner products:"
				for title, product of products
					message += "\n#{title} - #{product.name}"
				msg.send message
