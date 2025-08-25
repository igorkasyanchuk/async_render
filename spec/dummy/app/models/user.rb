class User < ApplicationRecord
  has_many :comments

  def bio
    Nokogiri::HTML.fragment("<html>
      <body>
        <h1>Hello</h1>
        <p>This is a bio</p>
      </body>
    </html>").text
  end
end
