import { graphql } from 'gatsby'
import { GatsbySeo } from 'gatsby-plugin-next-seo'
import React from 'react'

import Layout from '../../components/Layout'

const AboutPage = ({
  data: {
    teamMarkdownRemark: {  },
    site: {
      siteMetadata: { siteUrl, title: siteTitle, description: siteDescription },
    },
  },
}) => {
  return (
    <Layout>
      <GatsbySeo
        title={`L'équipe | ${siteTitle}`}
        description={siteDescription}
        canonical={`${siteUrl}about/`}
      />

      <section className="max-w-3xl mx-auto px-2 sm:px-4 xl:max-w-5xl xl:px-0">
        <div className="grid xs:grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">

        </div>
      </section>
    </Layout>
  )
}

export default AboutPage

export const pageQuery = graphql`
  query AboutPage {
    team: markdownRemark(
      skip: 0
      limit: 1
      filter: { frontmatter: { templateKey: { eq: "team" } } }
    ) {
      edges {
        node {
          frontmatter {
            members {
              name
              description
              position
              linkedin
              github
              stackoverflow
            }
          }
        }
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
