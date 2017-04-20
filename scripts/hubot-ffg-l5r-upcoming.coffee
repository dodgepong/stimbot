# Description:
#   Tool for notifying a chat room of changes to the FFG Upcoming page.
#
# Commands:
#	!l5rupcoming or !upcomingl5r - Displays a list of all upcoming L5R products.

REFRESH_FREQUENCY = 300000 # 5 min

products_match = (product1, product2) ->
	return product1.expected_by == product2.expected_by and product1.name == product2.name and product1.price == product2.price

sort_products = (product1, product2) ->
	if product1.order_index > product2.order_index
		return -1
	if product1.order_index < product2.order_index
		return 1
	return 0

select_emoji = (order_index) ->
	if order_index == 10
		return ":attheprinter:"
	if order_index == 20
		return ":ontheboat:"
	if order_index == 30
		return ":shippingnow:"
	if order_index == 5
		return ":awaitingreprint:"
	if order_index == 0
		return ":indevelopment:"
	if order_index == 40
		return ":instoresnow:"
	return ""


date_options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' }

module.exports = (robot) ->
	if process.env.ENABLE_L5R_UPCOMING_CHECKER is 'true'
		robot.logger.info "Enabling FFG L5R Upcoming Checker"
		setInterval () ->
			url = 'https://ffgupcomingapi.herokuapp.com/?root_collection=Legend%20of%20the%20Five%20Rings%3A%20The%20Card%20Game'
			upcoming_products = robot.brain.get('upcoming_products_l5r')
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
						if response.results.length == 0
							robot.logger.info "ZERO products found in API!"
						update_channel = false
						updated_products = {}
						update_message = ":alarm: Detected new changes to FFG Upcoming page for L5R:"
						for new_product in response.results
							if new_product.is_reprint == false
								continue
							updated_products[new_product.product] = new_product
							if new_product.product not of upcoming_products
								update_message += "\n• New product added! \"#{new_product.product}\" (#{new_product.name})"
								update_channel = true
								continue

							old_product = upcoming_products[new_product.product]
							if not products_match(old_product, new_product)
								changes = []
								if old_product.name != new_product.name
									changes.push "Status changed to #{new_product.name}"
								if old_product.expected_by != new_product.expected_by and new_product.expected_by != ''
									changes.push "Publish date changed to #{(new Date(new_product.expected_by)).toLocaleDateString('en-US', date_options)}"
								if old_product.price != new_product.price
									changes.push "Price changed to $#{new_product.price}"
								update_message += "\n• #{new_product.product} updated: #{changes.join(', ')}"
								update_channel = true
								continue

						# Notify channel of any changes
						if update_channel
							robot.logger.info "Notifying of new FFG L5R product updates"
							for room in process.env.FFG_L5R_UPCOMING_CHECKER_ROOMS.split(',')
								robot.messageRoom room, update_message

						# overwrite previous data with new data of all products
						robot.brain.set 'upcoming_products_l5r', updated_products
		, REFRESH_FREQUENCY
	else
		robot.logger.info "Disabling FFG L5R Upcoming Checker"

	robot.hear /!(l5rupcoming|upcomingl5r)/i, (msg) ->
		command = msg.match[1]
		if process.env.ENABLE_L5R_UPCOMING_CHECKER isnt 'true'
			msg.send "The FFG Upcoming bot is offline right now. You can see all upcoing FFG products here: https://www.fantasyflightgames.com/en/upcoming/"
		else
			products = robot.brain.get('upcoming_products_l5r')
			if !products?
				products = {}
			num_products = Object.keys(products).length
			if num_products is 0
				msg.send "There are no known upcoming products for L5R (or the notifier is not working). :("
			else
				message = "Upcoming L5R products:"
				items = Object.keys(products).map((key) ->
					return products[key]
				)
				items.sort(sort_products)
				for product in items
					message += "\n• #{select_emoji(product.order_index)} #{product.product} (#{product.collection}) - #{product.name}"
					if product.expected_by != "" and product.expected_by != null
						message += " - Expected by #{(new Date(product.expected_by)).toLocaleDateString('en-US', date_options)}"
				msg.send message
