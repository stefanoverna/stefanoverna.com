# module Jekyll
#   class MyExcerpt < Liquid::Block
#     def render(context)
#       # Get the current post's post object
#       id = context["page"]["id"]
#       posts = context.registers[:site].posts
#       post = posts [posts.index {|post| post.id == id}]

#       # Put the block contents into the post's excerpt field,
#       # and also return those contents
#       post.data["excerpt"] = super
#     end
#   end
# end

# Liquid::Template.register_tag('my_excerpt', Jekyll::Excerpt)

