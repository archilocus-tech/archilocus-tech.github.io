import { graphql } from 'gatsby'
import { GatsbyImage, getImage } from 'gatsby-plugin-image'
import {
  GatsbySeo,
  ArticleJsonLd,
} from 'gatsby-plugin-next-seo'
import PropTypes from 'prop-types'
import React from 'react'

import Layout from '../components/Layout'

const Event = ({
  data: {
    event,
    site: {
      siteMetadata: { siteUrl },
    },
  },
}) => {
  const url = `${siteUrl}${event.frontmatter.path}`
  const { description, date: publishedDate, title } = event.frontmatter

  return (
    <Layout>
      <GatsbySeo
        title={title}
        description={description}
        canonical={url}
        openGraph={{
          title,
          description,
          url,
          type: 'article',
          article: {
            publishedTime: publishedDate,
            modifiedTime: publishedDate,
          },
          // images: [
          //   {
          //     url: `${siteUrl}${getSrc(featuredimage)}`,
          //     alt: title,
          //   },
          // ],
        }}
      />
      <ArticleJsonLd
        url={url}
        headline={title}
        // images={[`${siteUrl}${getSrc(featuredimage)}`]}
        datePublished={publishedDate}
        dateModified={publishedDate}
        publisherLogo={`${siteUrl}/logo.png`}
        description={description}
        overrides={{
          '@type': 'Eventing',
        }}
      />

      <article className="max-w-2xl mx-auto px-4 sm:px-6 xl:max-w-4xl xl:px-0">
        <header className="pt-2 pb-2 lg:pb-4">
          <div className="space-y-4 text-left">
            <h1 className="text-3xl leading-12 text-gray-800 lg:text-4xl lg:leading-14 mb-2">
              {title}
            </h1>
            <p class="text-sm lg:text-base font-normal text-gray-600">Published {publishedDate}</p>
          </div>
        </header>

        <div class="container">
          <div class="flex flex-col md:grid grid-cols-12 text-gray-50">

            <div class="flex md:contents">
              <div class="col-start-2 col-end-4 mr-10 md:mx-auto relative">
                <div class="h-full w-6 flex items-center justify-center">
                  <div class="h-full w-1 bg-gray-300 pointer-events-none"></div>
                </div>
                <div class="w-6 h-6 absolute top-1/2 -mt-3 rounded-full bg-gray-300 shadow text-center">
                  <i class="fas fa-exclamation-circle text-gray-400"></i>
                </div>
              </div>
              <div class="bg-gray-300 col-start-4 col-end-12 p-4 rounded-xl my-4 mr-auto shadow-md w-full">
                <h3 class="font-semibold text-lg mb-1 text-gray-400">Delivered</h3>
                <p class="leading-tight text-justify">

                </p>
              </div>
            </div>
          </div>
        </div>
      </article>
    </Layout>
  )
}

Event.propTypes = {
  data: PropTypes.shape({
    markdownRemark: PropTypes.object,
  }),
}

export default Event

export const pageQuery = graphql`
  query EventByID($id: String!) {
    event: markdownRemark(id: { eq: $id }) {
      id
      html
      frontmatter {
        date
        title
        path
        description
      }
    }
    site {
      siteMetadata {
        title
        siteUrl
      }
    }
  }
`
