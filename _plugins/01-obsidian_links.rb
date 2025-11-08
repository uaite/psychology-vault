# Convert Obsidian-style wiki links [[Link]] to Jekyll-compatible markdown links
# Priority: 1 ensures this runs early
Jekyll::Hooks.register :site, :post_read do |site|
  # Build a lookup table of all pages
  @page_lookup = {}
  
  (site.pages + site.docs_to_write).each do |page|
    # Get the page name without extension
    basename = File.basename(page.path, '.*')
    # Store the relative URL from site root
    @page_lookup[basename] = page.url
  end
  
  # Debug: print some lookup entries
  puts "Wiki-link lookup table has #{@page_lookup.size} entries"
  puts "Sample: Classical Conditioning -> #{@page_lookup['Classical Conditioning']}" if @page_lookup['Classical Conditioning']
end

Jekyll::Hooks.register :documents, :pre_render do |document, payload|
  convert_obsidian_links(document, payload['site'])
end

Jekyll::Hooks.register :pages, :pre_render do |page, payload|
  convert_obsidian_links(page, payload['site'])
end

def convert_obsidian_links(doc, site)
  baseurl = site['baseurl'] || ''
  
  doc.content = doc.content.gsub(/\[\[([^\]|]+?)(?:\|([^\]]+?))?\]\]/) do
    link = $1.strip
    text = $2 ? $2.strip : $1.strip
    
    # Handle links with fragments (e.g., [[Page#Section]])
    if link.include?('#')
      page_name, fragment = link.split('#', 2)
      fragment = fragment.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')
      page_name = page_name.gsub(/\.md$/, '').strip
      
      # Look up the actual page URL
      if @page_lookup && @page_lookup[page_name]
        page_url = @page_lookup[page_name].gsub(/\/$/, '')
        # Use absolute path starting with /
        full_url = "#{baseurl}#{page_url}##{fragment}"
        "<a href=\"#{full_url}\">#{text}</a>"
      else
        # Fallback to simple conversion with absolute path
        full_url = "#{baseurl}/#{page_name.gsub(' ', '%20')}##{fragment}"
        "<a href=\"#{full_url}\">#{text}</a>"
      end
    else
      # Remove .md extension if present
      link = link.gsub(/\.md$/, '').strip
      
      # Look up the actual page URL
      if @page_lookup && @page_lookup[link]
        page_url = @page_lookup[link]
        # Use absolute path starting with /
        full_url = "#{baseurl}#{page_url}"
        "<a href=\"#{full_url}\">#{text}</a>"
      else
        # Fallback to simple conversion with absolute path
        full_url = "#{baseurl}/#{link.gsub(' ', '%20')}"
        "<a href=\"#{full_url}\">#{text}</a>"
      end
    end
  end
end
