class IndexPage < MainLayout
  def content
    div class: "p-2" do
      h1 class: "text-3xl font-bold underline text-red-600" do
        text "Hello World!"
      end
      div x_data: "{ count: 0 }" do
        button "x-on:click": "count++", class: "bg-blue-500 p-2 text-white round" do
          text "Increment"
        end
        br
        span x_text: "count", class: "text-green-600 text-4xl"
      end
    end
  end
end
