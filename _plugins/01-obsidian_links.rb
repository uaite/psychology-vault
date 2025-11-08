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
        "[#{text}](#{baseurl}#{page_url}##{fragment})"
      else
        # Fallback to simple conversion
        "[#{text}](#{baseurl}/#{page_name.gsub(' ', '%20')}##{fragment})"
      end
    else
      # Remove .md extension if present
      link = link.gsub(/\.md$/, '').strip
      
      # Look up the actual page URL
      if @page_lookup && @page_lookup[link]
        "[#{text}](#{baseurl}#{@page_lookup[link]})"
      else
        # Fallback to simple conversion
        "[#{text}](#{baseurl}/#{link.gsub(' ', '%20')})"
      end
    end
  end
end
