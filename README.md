# SymbilityIntersect-CodeChallenge1
A coding challenge for Symbility Intersect that is a cryptomarket app that allows the user to view a selection of over 2000 cryptocurrencies and favourite them with live price data that can be refreshed at the users discretion.


# Challenge
The challenging portion of this program was related to retreiving the price data for over 2000 coins, due to the fact that the endpoint to retrieve the coin prices themselves only took a maximum request of 300 characters per request and each coin is at minimum 3 characters long. This meant that ~36 requests have to be made in order to retrieve all the data, and to do this efficiently/fast was the challenge.

# Solution
Whilst making the initial request hitting the first endpoint to retrieve the names for all 2000+ coins, I save an array of strings that stores between 285-300 characters of comma seperated coin names. This array is then itereated and used to allow me to make 36 asychronus requests almost simultaneously and essentially allowing me to retrieve all this data as well as populate the table in about 3 seconds.

# Personal Decisions
- All coins are filtered by their respective sortOrder from the initial request to ensure that the table data is essentially sorted from the top ranked coin to the lowest ranked coin
- Only the top 150 coins have images to reduce the amount of data needed to be downloaded, considering caching is not implemented in this app
- Provided the ability to slide down from the top of the table view to refresh/repopulate the price data of all the coins in the table with the most recent and up to date prices. (Endpoint chaches the price data for 10 seconds must wait for > 10 seconds to actually see price updates when testing)

# With More Time...
With more time and with the mindset of creating this app to be a full application for real users to use I would ...
    - Set up caching so that user favourites are saved for the next time they open the app and so that all coins can have images
    - Set up searching so that users can filter through the coins and select the one they are looking for very easily
    - Set up a delegate/protocol for seguing from the splashScreen only when all coin/price data has been retrieved and the table has been populated

![splashscreen](https://user-images.githubusercontent.com/18080330/37580944-b6193f42-2b1c-11e8-8324-689d1c884094.jpg) ![initalload](https://user-images.githubusercontent.com/18080330/37580998-fa4e4900-2b1c-11e8-97a7-99cf0b2224d4.jpg)![favourited](https://user-images.githubusercontent.com/18080330/37581004-03b39356-2b1d-11e8-9b9b-35a7a5a54513.jpg)
