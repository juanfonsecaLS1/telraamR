library(httr)

headers = c(
  'X-Api-Key' = 'Your personal API Token comes here.'
)

res <- VERB("GET", url = "https://telraam-api.net/v1/cameras", add_headers(headers))

cat(content(res, 'text'))
