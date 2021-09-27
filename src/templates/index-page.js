import { graphql, Link } from 'gatsby'
import { GatsbySeo } from 'gatsby-plugin-next-seo'
import { OutboundLink } from 'gatsby-plugin-google-gtag'
import { StaticImage } from 'gatsby-plugin-image'
import React from 'react'
import PropTypes from 'prop-types'

import Layout from '../components/Layout'

const IndexPage = ({ data: { site: { siteMetadata: { title, description } }, eventsAllMarkdownRemark: { edges: eventsEdges } } }) => (
  <Layout>
    <GatsbySeo title={title} description={description} />

    <div className="-mt-24 relative w-full py-12 px-12 bg-yellow-900">
      <div className="relative z-10 text-center py-24 md:py-48">
        <h1 className="text-white text-center text-3xl md:text-4xl lg:text-5xl xl:text-6xl font-display font-bold mb-12">{title}</h1>
        <OutboundLink href="https://conference-hall.io/public/event/mY0LedHCginiRMKE7m1G" className="inline-block bg-yellow-800 text-white uppercase text-sm tracking-widest font-heading px-8 py-4">Call for Paper</OutboundLink>
      </div>

      {/* <div className="relative z-10 mx-auto max-w-4xl flex justify-between uppercase text-white font-heading tracking-widest text-sm">
		<a href="{{ home.link_one }}" className="border-b border-white">{{ home.link_one_text }}</a>
		<a href="{{ home.link_two }}" className="border-b border-white">{{ home.link_two_text }}</a>
	</div> */}

      <StaticImage src="../images/home-header-bg.jpg" className="w-full h-full absolute inset-0 object-cover opacity-70" alt={`${title} home background`} />
    </div>

    <div className="grid grid-cols-1 md:grid-cols-2">
      <div className="bg-white p-12 md:p-24 flex justify-end items-center">
        <a href="{{ post.url }}">
          <img src="{{ post.data.image }}" className="w-full max-w-md" />
        </a>
      </div>

      {/* <div className="bg-gray-100 p-12 md:p-24 flex justify-start items-center">
        <div className="max-w-md">
          <div className="w-24 h-2 bg-yellow-800 mb-4"></div>
          <h2 className="font-display font-bold text-2xl md:text-3xl lg:text-4xl mb-6">{{ post.data.title }}</h2>
          <p className="font-light text-gray-600 text-sm md:text-base mb-6 leading-relaxed">{{ post.data.description }}</p>
          <a href="{{ post.url }}" className="inline-block border-2 border-yellow-800 font-light text-yellow-800 text-sm uppercase tracking-widest py-3 px-8 hover:bg-yellow-800 hover:text-white">Read more</a>
        </div>
      </div> */}
    </div>
  </Layout>
)

IndexPage.propTypes = {
  data: PropTypes.shape({
    postsAllMarkdownRemark: PropTypes.shape({
      edges: PropTypes.arrayOf(PropTypes.object),
    }),
  }),
}

export default IndexPage

export const pageQuery = graphql`
  query IndexPageTemplate {
    eventsAllMarkdownRemark: allMarkdownRemark(
      sort: { fields: [frontmatter___date], order: DESC }
      skip: 0
      limit: 5
      filter: { frontmatter: { templateKey: { eq: "event" } } }
    ) {
      edges {
        node {
          frontmatter {
            title
            description
          }
          fields {
            slug
          }
        }
      }
    }
    site {
      siteMetadata {
        siteUrl
        title
        description
      }
    }
  }
`
