import { graphql } from 'gatsby'
import { GatsbySeo } from 'gatsby-plugin-next-seo'
import React from 'react'

import EventCard from '../../components/EventCard'
import Layout from '../../components/Layout'

const EventsIndexPage = ({
  data: {
    eventsAllMarkdownRemark: { edges: eventEdges },
    site: {
      siteMetadata: { siteUrl, title: siteTitle, description: siteDescription },
    },
  },
}) => {
  return (
    <Layout>
      <GatsbySeo
        title={`Précédent | ${siteTitle}`}
        description={siteDescription}
        canonical={`${siteUrl}precedent/`}
      />

      <section className="max-w-3xl mx-auto px-2 sm:px-4 xl:max-w-5xl xl:px-0">
        <div className="grid xs:grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
          {eventEdges.map(
            ({
              node: {
                frontmatter: { path, title, description },
              },
            }) => (
              <EventCard
                key={`events-index-event-${path}`}
                path={path}
                title={title}
                description={description}
              />
            )
          )}
        </div>
      </section>
    </Layout>
  )
}

export default EventsIndexPage

export const pageQuery = graphql`
  query EventIndexPage {
    eventsAllMarkdownRemark: allMarkdownRemark(
      sort: { fields: [frontmatter___date], order: DESC }
      skip: 0
      limit: 10
      filter: { frontmatter: { templateKey: { eq: "event" } } }
    ) {
      edges {
        node {
          frontmatter {
            path
            title
            description
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
