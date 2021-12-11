href(url::String) = "<a href='$url'>$url</a>"

hli(text) = "<li>$text</li>"

function html(changed::Vector{PageScan})
    urls = [string(scan.page.url)::String for scan in changed]
    items = hli.(href.(urls))
    text = join(items)
    return "Hi,<br><br>The following pages changed:<br><ul>$text</ul>- Skan.jl"
end

function send_mail!(
        changed::Vector{PageScan};
        recipient_mail=ENV["RECIPIENT_MAIL"],
        recipient_name=ENV["RECIPIENT_NAME"]
    )
    user = "4d6e91aa7d2d864edc1905e4498bf31e:74267154925f6be4d0710d39d7e487f1"
    url = "https://$user@api.mailjet.com/v3.1/send"
    headers = [
        "Content-Type" => "application/json"
    ]
    html_part = html(changed)
    body = """
        {
          "Messages":[
            {
              "From": {
                "Email": "t.h.huijzer@rug.nl",
                "Name": "Skanbot"
              },
              "To": [
                {
                  "Email": "$recipient_mail",
                  "Name": "$recipient_name"
                }
              ],
              "Subject": "Skan update",
              "TextPart": "The following pages changed:",
              "HTMLPart": "$html_part",
              "CustomID": "AppGettingStartedTest"
            }
          ]
        }
        """
    print(body)

    response = post(url, headers, body)
    return response
end
