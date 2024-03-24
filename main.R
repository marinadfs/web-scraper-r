library(rvest)

httr::set_config(httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"))

# initializing the lists that will store the scraped data
product_urls <- list()
product_images <- list()
product_names <- list()
product_prices <- list()

# initializing the page to scrape with the first pagination link
page_to_scrape <- "https://scrapeme.live/shop/page/1"

#enquanto houver uma pagina para fazer scrap,
#eu quero extrair os dados daquela página
#eu quero buscar a próxima página
#quando não houve mais páginas, eu quero transformar as informações em um data frame
#por fim, escrever o dataframe em um csv

while (page_to_scrape != "") {
  print(page_to_scrape)
  document <- read_html(page_to_scrape)
  # selecting the list of product HTML elements
  html_products <- document %>% html_elements("li.product")
  #Xpath = //li[@class="product"]/a
  product_urls <- c(product_urls,
    html_products %>%
      html_element("a") %>%
      html_attr("href")
  )

  product_images <- c(product_images,
    html_products %>%
      html_element("img") %>%
      html_attr("src")
  )

  product_names <- c(product_names,
    html_products %>%
      html_element("h2") %>%
      html_text2()
  )

  product_prices <- c(product_prices,
    html_products %>%
      html_element("span") %>%
      html_text2()
  )

  page_to_scrape <- document %>%
    html_element("a.next.page-numbers") %>%
    html_attr("href")
}

products <- data.frame(
  unlist(product_urls),
  unlist(product_images),
  unlist(product_names),
  unlist(product_prices)
)

# changing the column names of the data frame before exporting it into CSV
names(products) <- c("url", "image", "name", "price")
colnames(products)

# export the data frame containing the scraped data to a CSV file
write.csv(products, file = "./products.csv", fileEncoding = "UTF-8")
