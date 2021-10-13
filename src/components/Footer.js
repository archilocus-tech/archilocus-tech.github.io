import React from 'react'

import useSiteMetadata from '../queries/site-metadata'

const Footer = () => {
  const {
    description,
    title
  } = useSiteMetadata()

  return (
    <footer class="bg-gray-900 text-white text-opacity-40 font-semibold uppercase text-xs tracking-widest bg-opacity-80 px-12">
      <div class="container mx-auto grid grid-cols-1 lg:grid-cols-4 gap-12 text-center lg:text-left py-24">
        <div>
          <div class="text-white opacity-50 text-4xl font-display">{title}</div>
        </div>
        {/* <div>
			<div class="font-display text-white uppercase text-sm tracking-widest mb-6">{{ footer.section_one_title }}</div>
			{% for item in footer.section_one_links %}
				<a href="{{ item.url }}" class="block mb-4">{{ item.text }}</a>
			{% endfor %}
		</div>
		<div>
			<div class="font-display text-white uppercase text-sm tracking-widest mb-6">{{ footer.section_two_title }}</div>
			{% for item in footer.section_two_links %}
				<a href="{{ item.url }}" class="block mb-4">{{ item.text }}</a>
			{% endfor %}
		</div>
		<div>
			<div class="font-display text-white uppercase text-sm tracking-widest mb-6">{{ footer.section_three_title }}</div>
			{% for item in footer.section_three_links %}
				<a href="{{ item.url }}" class="block mb-4">{{ item.text }}</a>
			{% endfor %}
		</div> */}
      </div>
      <div class="text-sm lg:text-base text-center font-heading font-light tracking-widest uppercase text-white opacity-75 pb-24">
        {/* {{ footer.copyright }} */}
      </div>
    </footer>
  )
}

export default Footer
